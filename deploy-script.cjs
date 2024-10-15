'use strict';

var tsSdk = require('@aptos-labs/ts-sdk');

const APTOS_NETWORK = tsSdk.Network.DEVNET;
const config = new tsSdk.AptosConfig({network: APTOS_NETWORK});
const aptosClient = new tsSdk.Aptos(config);
const module$1 = "artemis_one";

async function main() {
    const adminPrivateKey = new tsSdk.Ed25519PrivateKey(process.env.ADMIN_PRIVATE_KEY);
    const admin = tsSdk.Account.fromPrivateKey({privateKey: adminPrivateKey});
    const alice = tsSdk.Account.fromPrivateKey({
        privateKey: new tsSdk.Ed25519PrivateKey('0xeb15ae1c953958b2bad5d7da3e83f4f18075aeb04d46803ef3845de207725409')
    });

    console.log(`Admin: ${admin.accountAddress.toString()}`);
    console.log(`Alice: ${alice.accountAddress.toString()}`);
    const assetName = 'Artwork #4';

    await createAsset(admin, assetName);
    await purchaseToken(alice, assetName);
}

async function createAsset(signer, assetName) {
    const data = [
        assetName,
        "Pakwali",
        "https://arteesan.io/pakwali",
        "Artemis Four",
        "ARTE04",
        BigInt(1000),
        BigInt(100000)
    ];
    const tx = await constructTx(signer, 'create_asset', data);
    const senderAuthenticator = await aptosClient.transaction.sign({signer: signer, transaction: tx});
    const pendingTx = await aptosClient.transaction.submit.simple({transaction: tx, senderAuthenticator});
    console.log(pendingTx.hash);
    return pendingTx.hash;
}

async function purchaseToken(sender, asset_name) {
    const data = [
        BigInt(200),
        asset_name
    ];
    const tx = await constructTx(sender, 'purchase_fractional_ownership', data);
    const senderAuthenticator = await aptosClient.transaction.sign({signer: sender, transaction: tx});
    const pendingTx = await aptosClient.transaction.submit.simple({transaction: tx, senderAuthenticator});
    console.log(pendingTx.hash);
    return pendingTx.hash;
}

async function constructTx(sender, functionName, data) {
    return await aptosClient.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `${process.env.ADMIN_ACCOUNT}::${module$1}::${functionName}`,
            functionArguments: data
        }
    });
}

main().then(() => {
    console.log("Exit without error");
}).catch(err => {
    console.error(err);
});
//# sourceMappingURL=deploy-script.cjs.map
