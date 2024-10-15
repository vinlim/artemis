<script setup lang="ts">
import {RouterLink, RouterView} from 'vue-router'
import AcHeader from "@/components/AcHeader.vue";
import Utils from "@/utils/utils";
import {useWalletStore} from "@/stores/wallet";

const walletStore = useWalletStore();

async function connectWallet() {
  try {
    const response = await Utils.getAptosWallet().account();
    if (response) {
      walletStore.connect(response);
    }
  } catch (error) {
    // { code: 4001, message: "User rejected the request."}
  }
}

connectWallet();
</script>


<template>
  <div class="w-full h-full flex flex-col justify-start items-start">
    <ac-header></ac-header>
    <RouterView class="grow"/>
  </div>

</template>