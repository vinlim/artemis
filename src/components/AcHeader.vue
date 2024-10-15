<script setup lang="ts">

import Utils from "../utils/utils";
import {useWalletStore} from "@/stores/wallet";

const walletStore = useWalletStore();

async function connectWallet() {
  try {
    const response = await Utils.getAptosWallet().connect();
    walletStore.connect(response);
  } catch (error) {
    // { code: 4001, message: "User rejected the request."}
  }
}

async function disconnectWallet() {
  await Utils.getAptosWallet().disconnect();
  walletStore.disconnect();
}
</script>

<template>
  <header class="w-full h-[65px] bg-gray border-b-[1px] border-gray:50 z-10">
    <div class="h-full container mx-auto flex justify-between items-center font-serif">
      <a class="text-xl font-thin" href="/">Artemis Collective</a>
      <div class="flex justify-end items-center gap-3">
        <a href="/explore">Explore</a>
        <a href="/">How It Works</a>
        <a href="/">Our Team</a>
        <button v-if="!walletStore.connected" class="border-[1px] border-gray-300 px-3 py-2 rounded-sm"
                @click="connectWallet">
          Connect Wallet
        </button>
        <button v-if="walletStore.connected" class="border-[1px] border-gray-300 px-3 py-2 rounded-sm"
                @click="disconnectWallet">
          {{ Utils.truncateAddress(walletStore.address) }}
        </button>
      </div>
    </div>
  </header>
</template>

<style scoped>

</style>