<template>
  <div class="px-5 py-3">
    <div class="flex justify-between">
      <a href="/"><img src="/logo.png" alt="logo" width="50" class="rounded-full object-cover lg:h-14 w-10 lg:w-14 h-10"></a>
      <div><w3m-button /></div>
    </div>
    <div class="pt-10">
      <div class="flex items-center flex-col lg:flex-row">
        <TokenInfo class="lg:pr-8 mb-10 lg:mb-0 text-center lg:text-left" />
        <Presale />
      </div>
      <div class="uppercase lg:text-[8rem] text-[4rem] text-center font-bold mt-4 text-gray-800 mb-[-4rem] lg:mb-[-8rem]">Socials</div>
      <div class="flex lg:text-[5rem] justify-center lg:space-x-5 space-x-3 text-[3rem] ">

        <a :href="config.soc.discord" v-if="config.soc.discord"
          class="hover:text-green-400 transition transform hover:scale-110" target="_blank">
          <UIcon dynamic name="bxl:discord-alt" />
        </a>
        <a :href="config.soc.twitter" v-if="config.soc.twitter"
          class="hover:text-green-400 transition transform hover:scale-110" target="_blank">
          <UIcon dynamic name="bxl:twitter" />
        </a>
        <a :href="config.soc.telegram" v-if="config.soc.telegram"
          class="hover:text-green-400 transition transform hover:scale-110" target="_blank">
          <UIcon dynamic name="bxl:telegram" />
        </a>

      </div>
    </div>
    <UNotifications />
  </div>
</template>

<script setup>
import { createWeb3Modal, defaultConfig } from '@web3modal/ethers/vue'
import { config } from "./config"

// 1. Define constants
const projectId = '2d808c74f09dccab69c662b496f8c82b'

const mainnet = {
  chainId: 84532,
  name: 'Base Sepolia',
  currency: 'ETH',
  explorerUrl: 'https://sepolia-explorer.base.org',
  rpcUrl: 'https://sepolia.base.org'
}

// 3. Create your application's metadata object
const metadata = {
  name: 'My Website',
  description: 'My Website description',
  url: 'https://mywebsite.com', // url must match your domain & subdomain
  icons: ['https://avatars.mywebsite.com/']
}


// 4. Create Ethers config
const ethersConfig = defaultConfig({
  /*Required*/
  metadata,

  /*Optional*/
  enableInjected: true, // true by default
  defaultChainId: 84532, // used for the Coinbase SDK
})

// 5. Create a Web3Modal instance
const modal = createWeb3Modal({
  ethersConfig,
  chains: [mainnet],
  projectId,
  enableAnalytics: true, // Optional - defaults to your Cloud configuration
  themeVariables: {
    '--w3m-accent': 'rgb(74 222 128 / 0.8)',
  }
})
</script>
