<template>
  <main class="h-full w-full flex justify-start items-center">
    <div class="h-full w-full grow p-2 overflow-x-auto flex gap-6 snap-mandatory snap-x">
      <div class="w-[75%] shrink-0 snap-center flex justify-center items-center">
        <div class="w-[80%] h-[80%] border-[1px] border-gray-200 border flex justify-center items-center bg-gray-50">
          <img
              src="https://arteesan-files.sgp1.digitaloceanspaces.com/5195/conversions/First_last-artikarya_01-fhd.jpg">
        </div>
      </div>
      <div class="w-[75%] shrink-0 snap-center flex justify-center items-center">
        <div class="w-[80%] h-[80%] border-[1px] border-gray-200 border flex justify-center items-center bg-gray-50">
          <img
              src="https://arteesan-files.sgp1.digitaloceanspaces.com/5197/conversions/third_last-artikarya_01-fhd.jpg">
        </div>
      </div>
      <div class="w-[75%] shrink-0 snap-center flex justify-center items-center">
        <div class="w-[80%] h-[80%] border-[1px] border-gray-200 border flex justify-center items-center bg-gray-50">
          <img
              src="https://arteesan-files.sgp1.digitaloceanspaces.com/5201/conversions/seventh_final-artikarya_01-fhd.jpg">
        </div>
      </div>
    </div>
    <div class="h-full w-[28em] p-2 bg-gray-50 flex justify-center items-center">
      <div class="w-full p-6">
        <div class="mb-12">
          <div class="mb-3">
            <h1 class="font-serif font-mono">Myth of the Dragon Girl</h1>
            <h2 class="text-gray-500 font-serif">Chros, b 1987</h2>
          </div>
          <div class="text-xs">
            <p>
              A modern reinterpretation of traditional Chinese narrative through the creation of digital illustration.
              The Myth of Dragon Girl’, also known as ‘Legend of Liu Yi’, a story about a young scholar who fall in love
              with the Dragon Girl and rescued her from her evil husband. This study aims to investigate the process of
              recreating the narrative in the form of digital illustration, including storyline adaptation, character
              design, and explore how to integrate traditional Chinese elements with modern techniques. First, focuses
              on the narrative in different versions of interpretation to analyze the development of storyline and
              character traits; then, retains the main structure, acquire the essence of each edition, and adapts the
              plots.
            </p>
          </div>
        </div>
        <div class="text-black-800">
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Symbol</div>
            <div>ARTE01</div>
          </div>
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Total Fractions</div>
            <div>1000</div>
          </div>
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Available Fraction</div>
            <div>280</div>
          </div>
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Your Fraction</div>
            <div>-</div>
          </div>
          <div class="w-full mb-2 py-3">
            <div class="grid grid-cols-7">
              <input v-model="purchaseAmount" class="h-full col-span-5 px-3 py-2 text-center" type="number" step="1"
                     min="1" max="720"
                     placeholder="100">
              <button class="col-span-2 text-sm bg-gray-800 text-gray-50 px-3 py-2"
                      @click="purchase">
                Purchase
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
import {Aptos, AptosConfig, Network} from "@aptos-labs/ts-sdk";
import Utils from "@/utils/utils";
import {onMounted, ref} from "vue";
import {useWalletStore} from "@/stores/wallet";

const walletStore = useWalletStore();
const purchaseAmount = ref(0);
let APTOS_NETWORK = Network.DEVNET;
let config = new AptosConfig({network: APTOS_NETWORK});
let aptosClient = new Aptos(config)


onMounted(() => {
  getAccountResource();
})
async function getAccountResource() {
  // const tokens = await aptosClient.getAccountResource({
  //   accountAddress: "0xbdb72464e382add52ffbf7f66f689948885831dc14f585685487c9d6945ca846",
  //   resourceType: "0x1::fungible_asset::FungibleStore"
  // });
  //
  // console.log(tokens);
}

async function purchase() {
  if (purchaseAmount.value < 1) {
    alert('Minimum fraction is 1');
    return;
  }

  const transaction = {
    arguments: [purchaseAmount.value, "Artwork #4"],
    function: '0x08716457dd4c48f20cdbe240205a1c68e9f411a60fa2fd659265da35ed517340::artemis_one::purchase_fractional_ownership',
    type: 'entry_function_payload',
    type_arguments: [],
  };

  try {
    let wallet = await Utils.getAptosWallet();
    let pendingTransaction = await wallet?.signAndSubmitTransaction({payload: transaction});
    const txn = await aptosClient.getTransactionByHash(pendingTransaction.hash);
    console.log(txn);
  } catch (error) {
    console.log(error);
    // console.error(error);
  }
}
</script>