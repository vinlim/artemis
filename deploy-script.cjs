'use strict';

var tsSdk = require('@aptos-labs/ts-sdk');

const APTOS_NETWORK = tsSdk.Network.TESTNET;
const config = new tsSdk.AptosConfig({network: APTOS_NETWORK});
const aptosClient = new tsSdk.Aptos(config);
const module$1 = "artemis_one";
const assets = [
    {
        name: 'The Pink Peonies',
        artist: "Fathima Aafreen",
        url: "https://arteesan.io/api/token/acv/79",
        tokenName: "Artemis Nine",
        tokenSymbol: "ARTE09"
    }
];

async function main() {
    const adminPrivateKey = new tsSdk.Ed25519PrivateKey(process.env.VITE_ADMIN_PRIVATE_KEY);
    const admin = tsSdk.Account.fromPrivateKey({privateKey: adminPrivateKey});
    const alice = tsSdk.Account.fromPrivateKey({
        privateKey: new tsSdk.Ed25519PrivateKey('0x4aa80640e1e35caee30b40807baea0ba9ead4c9ad2d4305d0458f0d59091c5d9')
    });

    console.log(`Admin: ${admin.accountAddress.toString()}`);
    console.log(`Alice: ${alice.accountAddress.toString()}`);

    for (let asset of assets) {
        console.log(`Creating asset: ${asset.name}`);
        await createAsset(admin, asset.name, asset.artist, asset.url, asset.tokenName, asset.tokenSymbol);
    }

    // await purchaseToken(alice, assetName);
}

async function createAsset(signer, assetName, artist, url, tokenName, tokenSymbol) {
    const data = [
        assetName,
        artist,
        url,
        tokenName,
        tokenSymbol,
        BigInt(1000),
        BigInt(100000)
    ];
    const tx = await constructTx(signer, 'create_asset', data);
    const senderAuthenticator = await aptosClient.transaction.sign({signer: signer, transaction: tx});
    const pendingTx = await aptosClient.transaction.submit.simple({transaction: tx, senderAuthenticator});
    console.log(pendingTx.hash);
    return pendingTx.hash;
}

async function constructTx(sender, functionName, data) {
    return await aptosClient.transaction.build.simple({
        sender: sender.accountAddress,
        data: {
            function: `${process.env.VITE_ADMIN_ACCOUNT}::${module$1}::${functionName}`,
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
