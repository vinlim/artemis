import {
    Account,
    Aptos,
    AptosConfig,
    Ed25519PrivateKey,
    Network,
} from "@aptos-labs/ts-sdk";


const APTOS_NETWORK: Network = Network.DEVNET;
const config = new AptosConfig({network: APTOS_NETWORK});
const aptos = new Aptos(config);

async function main() {
    const adminPrivateKey = new Ed25519PrivateKey(process.env.ADMIN_PRIVATE_KEY);
    const admin = Account.fromPrivateKey({privateKey: adminPrivateKey})
    const alice = Account.generate();

    console.log(`Admin: ${admin.accountAddress.toString()}`);
    console.log(`Alice: ${alice.accountAddress.toString()}`);

    const tx = await aptos.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `${process.env.ADMIN_ACCOUNT}::artemis_one::create_asset`,
            functionArguments: [
                "Artwork #2",
                "Pakwali",
                "https://arteesan.io/pakwali",
                "Artemis Two",
                "ARTE02",
                BigInt(10000),
                10000000
            ]
        }
    });

    const senderAuthenticator = await aptos.transaction.sign({signer: admin, transaction: tx});
    const pendingTxn = await aptos.transaction.submit.simple({transaction: tx, senderAuthenticator});
    console.log("Create Token Hash: ", pendingTxn.hash);

    return pendingTxn.hash;
}

main().then(() => {
    console.log("Exit without error");
}).catch(err => {
    console.error(err);
});