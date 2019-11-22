import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:equatable/equatable.dart';
import 'package:hex/hex.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';
import '../wallet/sacco.dart';
import '../wallet/utils/bech32_encoder.dart';

import 'utils/tx_signer.dart';

import '../server/walletdb.dart';

/// Represents a wallet which contains the hex private key, the hex public key
/// and the hex address.
/// In order to create one properly, the [Wallet.derive] method should always
/// be used.
/// The associated [networkInfo] will be used when computing the [bech32Address]
/// associated with the wallet.
class Wallet extends Equatable {
  static const DERIVATION_PATH = "m/44'/118'/0'/0/0";

  final Uint8List address;
  final Uint8List privateKey;
  final Uint8List publicKey;

  final NetworkInfo networkInfo;

  Wallet({
    @required this.networkInfo,
    @required this.address,
    @required this.privateKey,
    @required this.publicKey,
  })  : assert(networkInfo != null),
        assert(privateKey != null),
        assert(publicKey != null),
        super([networkInfo, address, privateKey, publicKey]);

  /// Derives the private key from the given [mnemonic] using the specified
  /// [networkInfo].
  factory Wallet.derive(
    List<String> mnemonic,
    NetworkInfo networkInfo, String name, [String isPrivate]
) {
    // Get the mnemonic as a string
    final mnemonicString = mnemonic.join(' ');
    if (!bip39.validateMnemonic(mnemonicString)) {
      throw Exception("Invalid mnemonic " + mnemonicString);
    }

    // Convert the mnemonic to a BIP32 instance
    final seed = bip39.mnemonicToSeed(mnemonicString);
    final root = bip32.BIP32.fromSeed(seed);

    // Get the node from the derivation path
    final derivedNode = root.derivePath(DERIVATION_PATH);

    // Get the curve data
    final secp256k1 = ECCurve_secp256k1();
    final point = secp256k1.G;

    // Compute the curve point associated to the private key
    final bigInt = BigInt.parse(HEX.encode(derivedNode.privateKey), radix: 16);
    final curvePoint = point * bigInt;

    // Get the public key
    final publicKeyBytes = curvePoint.getEncoded();

    // Get the address
    final sha256Digest = SHA256Digest().process(publicKeyBytes);
    final address = RIPEMD160Digest().process(sha256Digest);

      //添加字段到数据库
    print("-------------");
    var db = DatabaseHelper();
    User user = new User();
    user.name = name;
    user.address = address.toString();
    user.privatekeyBytes = derivedNode.privateKey.toString();
    user.publicKeyBytes = publicKeyBytes.toString();
    
    db.saveItem(user);


  //   print(Wallet(
  //  networkInfo: networkInfo,
  //     address: address,
  //     privateKey: derivedNode.privateKey,
  //     publicKey: publicKeyBytes,
  //   ).networkInfo);
    print("-------------!");
    // Return the key bytes
    return Wallet(
      address: address,
      publicKey: publicKeyBytes,
      privateKey: derivedNode.privateKey,
      networkInfo: networkInfo,
    );

  }

  /// Creates a new [Wallet] instance based on the existent [wallet] for
  /// the given [networkInfo].
  factory Wallet.convert(Wallet wallet, NetworkInfo networkInfo) {
    return Wallet(
      networkInfo: networkInfo,
      address: wallet.address,
      privateKey: wallet.privateKey,
      publicKey: wallet.publicKey,
    );
  }

  /// Returns the associated [address] as a Bech32 string.
  String get bech32Address =>
      Bech32Encoder.encode(networkInfo.bech32Hrp, address);

  /// Returns the associated [privateKey] as an [ECPrivateKey] instance.
  ECPrivateKey get _ecPrivateKey {
    final privateKeyInt = BigInt.parse(HEX.encode(privateKey), radix: 16);
    return ECPrivateKey(privateKeyInt, ECCurve_secp256k1());
  }

  /// Returns the associated [publicKey] as an [ECPublicKey] instance.
  ECPublicKey get ecPublicKey {
    final secp256k1 = ECCurve_secp256k1();
    final point = secp256k1.G;
    final curvePoint = point * _ecPrivateKey.d;
    return ECPublicKey(curvePoint, ECCurve_secp256k1());
  }

  /// Signs the given [data] using the associated [privateKey] and encodes
  /// the signature bytes to be included inside a transaction.
  Uint8List signTxData(Uint8List data) {
    final hash = SHA256Digest().process(data);
    return TransactionSigner.deriveFrom(hash, _ecPrivateKey, ecPublicKey);
  }

  /// Generates a SecureRandom
  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(new KeyParameter(new Uint8List.fromList(seed)));
    return secureRandom;
  }

  /// Signs the given [data] using the private key associated with this wallet,
  /// returning the signature bytes ASN.1 DER encoded.
  Uint8List sign(Uint8List data) {
    final ecdsaSigner = Signer("SHA-256/ECDSA")
      ..init(
          true,
          ParametersWithRandom(
            PrivateKeyParameter(_ecPrivateKey),
            _getSecureRandom(),
          ));
    ECSignature ecSignature = ecdsaSigner.generateSignature(data);
    final sequence = ASN1Sequence();
    sequence.add(ASN1Integer(ecSignature.r));
    sequence.add(ASN1Integer(ecSignature.s));
    return sequence.encodedBytes;
  }

  /// Creates a new [Wallet] instance from the given [json] and [privateKey].
  factory Wallet.fromJson(Map<String, dynamic> json, Uint8List privateKey) {
    return Wallet(
      address: HEX.decode(json["hex_address"] as String),
      publicKey: HEX.decode(json['public_key'] as String),
      privateKey: privateKey,
      networkInfo: NetworkInfo.fromJson(json['network_info']),
    );
  }

  /// Converts the current [Wallet] instance into a JSON object.
  /// Note that the private key is not serialized for safety reasons.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'hex_address': HEX.encode(this.address),
        'bech32_address': this.bech32Address,
        'public_key': HEX.encode(this.publicKey),
        'network_info': this.networkInfo.toJson(),
      };
}
