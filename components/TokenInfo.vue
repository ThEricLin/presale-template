<template>
    <div>
        <h2 class="text-6xl" v-html="config.title"></h2>
        <div class="mt-4 text-gray-500" v-html="config.description">


        </div>
    </div>
</template>

<script setup>
import { config } from '~/config';

</script>