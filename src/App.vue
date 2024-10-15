<script setup lang="ts">
import {RouterLink, RouterView} from 'vue-router'
import AcHeader from "@/components/AcHeader.vue";
</script>


<template>
  <div class="w-full h-full flex flex-col justify-start items-start">
    <ac-header></ac-header>
    <RouterView class="grow"/>
  </div>

</template>