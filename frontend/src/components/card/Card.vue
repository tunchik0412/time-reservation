<script setup lang="ts">

import { defineProps } from 'vue'

const props = defineProps({
  active: Boolean,
  src: String,
  text: String
})
</script>

<template>
  <div :class="['card-wrapper', {active: props.active}]">
    <div class="image-wrapper">
      <div class="image-background">
        <img :src="props.src" alt="Card Image" />
      </div>
    </div>
    <p>{{props.text}}</p>
  </div>
</template>

<style scoped type="text/scss">
  .card-wrapper {
    .image-wrapper {

    }
  }
</style>
