import {
    Account,
    Aptos,
    AptosConfig,
    Ed25519PrivateKey,
    Network,
} from "@aptos-labs/ts-sdk";


const APTOS_NETWORK = Network.TESTNET;
const config = new AptosConfig({network: APTOS_NETWORK});
const aptosClient = new Aptos(config);
const module = "artemis_one";
const assets = [
    {
        name: 'The Pink Peonies',
        artist: "Fathima Aafreen",
        url: "https://arteesan.io/api/token/acv/79",
        tokenName: "Artemis Nine",
        tokenSymbol: "ARTE09"
    }
]

async function main() {
    const adminPrivateKey = new Ed25519PrivateKey(process.env.VITE_ADMIN_PRIVATE_KEY);
    const admin = Account.fromPrivateKey({privateKey: adminPrivateKey})
    const alice = Account.fromPrivateKey({
        privateKey: new Ed25519PrivateKey('0x4aa80640e1e35caee30b40807baea0ba9ead4c9ad2d4305d0458f0d59091c5d9')
    });

    console.log(`Admin: ${admin.accountAddress.toString()}`);
    console.log(`Alice: ${alice.accountAddress.toString()}`);
    const assetName = 'Cerita Seorang Rakan';

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

async function purchaseToken(sender, asset_name) {
    const data = [
        BigInt(200),
        asset_name
    ]
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
            function: `${process.env.VITE_ADMIN_ACCOUNT}::${module}::${functionName}`,
            functionArguments: data
        }
    });
}

main().then(() => {
    console.log("Exit without error");
}).catch(err => {
    console.error(err);
});