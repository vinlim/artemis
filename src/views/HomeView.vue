<script setup lang="ts">
import TheWelcome from '../components/TheWelcome.vue'
</script>

<template>
  <main class="h-full w-full flex justify-center items-center">
    <div class="flex justify-center items-center gap-6 pb-24">
      <img class="border-gray-200 border-[1px] p-8 rounded" src="/snp.png">
      <div class="w-[300px] h-full">
        <h1 class="font-serif font-bold text-2xl text-gray-700">Art consistently outperformed S&P500</h1>
        <p class="text-sm mb-3 text-bold text-lg text-gray-700">Provided you can afford</p>
        <p class="text-sm mb-3">Art’s historically low correlation to the stock market, potentially lucrative returns,
          and
          potential ability to hedge against inflation makes art investment funds a much sought after investment
          opportunity for
          investors</p>
        <p class="text-sm mb-6">The big caveat is, the entry is high, and you need to be in the know. Artemis Collective lets
          you invest into part of a bluechip artwork, according to your appetite.</p>
        <a href="/explore" class="bg-gray-800 px-3 py-3 rounded-lg text-gray-50">Explore now</a>
      </div>
    </div>
  </main>
</template>
