<template>
  <main class="h-full w-full flex justify-start items-center">
    <div class="h-full w-full grow p-2 overflow-x-auto flex gap-6 snap-mandatory snap-x" @scroll="handleScroll">
      <div v-for="asset in tokenizedAssets"
           class="w-[75%] shrink-0 snap-center flex justify-center items-center">
        <div class="w-[80%] h-[80%] border-[1px] border-gray-200 border flex justify-center items-center bg-gray-50">
          <img class="max-h-[500px]"
               :src="asset.meta.image">
        </div>
      </div>
      <div v-if="tokenizedAssets.length === 0"
           class="w-[75%] shrink-0 snap-center flex justify-center items-center">
        <div
            class="w-[80%] h-[80%] border-[1px] border-gray-200 animate-fade border flex justify-center items-center bg-gray-50">
          <div class="animate-pulse font-italic font-light text-sm">Curating artworks...</div>
        </div>
      </div>
    </div>
    <div class="h-full w-[28em] p-2 bg-gray-50 flex justify-center items-center border-l-[1px] border-gray-800">
      <div class="w-full p-6">
        <div class="mb-12">
          <div class="mb-3">
            <h1 class="font-serif font-mono">{{ tokenizedAssets[0]?.meta?.name }}</h1>
            <h2 class="text-gray-500 font-serif">{{ tokenizedAssets[0]?.meta?.properties?.Creator?.description }}, b
              1987</h2>
          </div>
          <div class="text-xs max-h-[240px] text-ellipsis overflow-y-auto">
            <p class="capitalize">{{ tokenizedAssets[0]?.meta?.description }}</p>
          </div>
        </div>
        <div class="text-black-800">
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Symbol</div>
            <div>{{ symbol }}</div>
          </div>
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Total Fractions</div>
            <div>{{ totalSupply }}</div>
          </div>
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Available Fraction</div>
            <div>{{ balanceSupply }}</div>
          </div>
          <div class="flex justify-between items-center mb-2">
            <div class="font-serif">Your Fraction</div>
            <div>{{ userSupply > 0 ? userSupply : '-' }}</div>
          </div>
          <div v-if="!isLoading"
               class="w-full mb-2 py-3">
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
          <div v-else class="w-full mb-2 py-3">
            <div class="w-full h-[2rem] bg-gray-400 animate-pulse text-gray-200 flex justify-center items-center">
              Transacting ...
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

const adminAccount = import.meta.env.VITE_ADMIN_ACCOUNT;
const walletStore = useWalletStore();
const purchaseAmount = ref(0);
const isLoading = ref(false);
let tokenizedAssets = ref([]);
let symbol = ref('ARTE04');
let totalSupply = ref(0);
let balanceSupply = ref(0);
let userSupply = ref(0);
let APTOS_NETWORK = Network.TESTNET;
let config = new AptosConfig({network: APTOS_NETWORK});
let aptosClient = new Aptos(config)

function handleScroll(event) {
}

async function getCollectionList() {
  let assets = await aptosClient.getOwnedDigitalAssets({
    ownerAddress: adminAccount,
  });

  for (let asset of assets) {
    let data = await aptosClient.getDigitalAssetData({
      digitalAssetAddress: asset.token_data_id,
    });
    let metaResponse = await fetch(data.token_uri)
    data.meta = await metaResponse.json();
    tokenizedAssets.value.push(data);
  }
}


async function getAccountResource() {
  const payload = {
    function: `${adminAccount}::artemis_one::get_asset_supply_and_balance`,
    functionArguments: [
      walletStore.address,
      tokenizedAssets.value[0]?.token_name
    ]
  };

  let balance = (await aptosClient.view({payload}))[0];
  totalSupply.value = balance.total_supply;
  userSupply.value = balance.user_balance;
  balanceSupply.value = totalSupply.value - userSupply.value;
}

onMounted(() => {
  init()
})

async function init() {
  await getCollectionList();
  if (walletStore.connected) {
    getAccountResource();
  }
}

async function purchase() {
  if (purchaseAmount.value < 1) {
    alert('Minimum fraction is 1');
    return;
  }

  isLoading.value = true;
  const transaction = {
    arguments: [purchaseAmount.value, tokenizedAssets.value[0]?.token_name],
    function: `${adminAccount}::artemis_one::purchase_fractional_ownership`,
    type: 'entry_function_payload',
    type_arguments: [],
  };

  try {
    let wallet = await Utils.getAptosWallet();
    await wallet?.signAndSubmitTransaction({payload: transaction});
    purchaseAmount.value = 0;
    await getAccountResource();
  } catch (error) {
    console.error(error);
  }
  isLoading.value = false;
}
</script>