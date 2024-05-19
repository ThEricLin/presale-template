<template>
    <div class="lg:w-[500px] w-full shrink-0 ">
        <UCard>
            <h2 class="text-xl uppercase text-center font-bold mb-1">Buy {{ config.tokenName }}</h2>
            <div class="text-center uppercase text-gray-400 font-bold mb-4">
                Available {{ availableAmount }} {{ config.tokenSymbol }}
            </div>
            <div class="">
                <UButtonGroup size="xl" orientation="horizontal" class="w-full">
                    <UInput type="number" v-model.number="ethValue" size="xl" class="font-bold flex-1"
                        @update:model-value="onEthUpdate" step="any"
                        input-class="pl-16 ps-16 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
                        <template #leading>
                            <span class="border-r border-gray-700 pr-3">
                                <UIcon class="text-2xl" dynamic name="cryptocurrency-color:eth"></UIcon>
                            </span></template>
                    </UInput>
                    <UButton @click.prevent="setMaxAmount" color="gray">MAX</UButton>
                </UButtonGroup>

                <div class="flex">
                    <div v-if="ethError" class="text-red-500 text-sm pt-1">
                        {{ ethError }}
                    </div>
                    <div class="mt-0 text-sm ml-auto text-right text-gray-400">
                        Balance: <UButton class="px-0" variant="link" @click.prevent="setEthBalance">{{
                            walletBalance.toFixed(3)
                        }} ETH</UButton>
                    </div>
                </div>

                <UInput v-model="tokenValue" size="xl" class="font-bold mt-3" @update:model-value="onTokenUpdate"
                    input-class="pl-16 ps-16 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                    type="number">
                    <template #leading>
                        <span class="border-r border-gray-700 pr-3">
                            <img src="/logo.png" alt="logo"
                                class="w-[1.5rem] h-[1.5rem] rounded-full border border-white">
                        </span></template>
                </UInput>
               
                <div class="flex">
                    <div v-if="tokenError" class="text-red-500 text-sm pt-1">
                        {{ tokenError }}
                    </div>
                    <div class="ml-auto mt-0 text-sm text-right text-gray-400">
                    Balance: <UButton class="px-0" variant="link">{{
                        tokenBalance.toFixed(3)
                        }} {{ config.tokenSymbol }}</UButton>
                </div>
                </div>
            </div>
            <UButton @click.prevent="buy" size="xl" class="w-full uppercase text-center justify-center mt-5"
                :loading="isLoading" :disabled="buyDisabled">
                Buy</UButton>
        </UCard>
        <div class="flex space-x-4 py-3 hidden">
            <UButton @click="buy">Buy</UButton>
            <UButton @click="withdraw">Withdraw Tokens</UButton>
            <UButton @click="withdrawEth">Withdraw ETH</UButton>
            <UButton @click="setPrice">Set Price</UButton>
        </div>
    </div>
</template>
<script setup>
import presaleAbi from "../contracts/presale-abi.json"
import erc20Abi from "../contracts/erc20-abi.json"

import { useWeb3ModalProvider, } from '@web3modal/ethers/vue';
import * as ethers from "ethers"
import { config } from "~/config";
const isLoading = ref(false)
const ethValue = ref(0)
const tokenValue = ref(0)
const tokenPrice = ref(0)
const availableAmount = ref(0);
const walletBalance = ref(0)
const contractAddress = config.contractAddress
const tokenAddress = ref('')
const tokenBalance = ref(0)
const { walletProvider } = useWeb3ModalProvider()

const onTokenUpdate = () => {
    ethValue.value = parseFloat((tokenValue.value * tokenPrice.value).toFixed(5))

}
const onEthUpdate = () => {
    tokenValue.value = parseFloat((ethValue.value / tokenPrice.value).toFixed(5))
}
const setMaxAmount = () => {
    tokenValue.value = availableAmount.value
    nextTick(() => { onTokenUpdate() })
}
const getContract = async () => {
    const provider = new ethers.BrowserProvider(walletProvider.value)
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, presaleAbi, signer)
    return contract
}
const setEthBalance = () => {
    ethValue.value = walletBalance.value
    onEthUpdate()
}
const getBalance = async () => {
    const provider = new ethers.BrowserProvider(walletProvider.value)
    const signer = await provider.getSigner()
    const balance = ethers.formatEther(await provider.getBalance(signer.address))

    walletBalance.value = parseFloat(parseFloat(balance).toFixed(5))
}

const getTokenBalance = async () => {
    const provider = new ethers.BrowserProvider(walletProvider.value)
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(tokenAddress.value, erc20Abi, signer)

    const balance = ethers.formatEther(await contract.balanceOf(signer.address))
    tokenBalance.value = parseFloat(parseFloat(balance).toFixed(5))
}

const init = async () => {
    if (!walletProvider.value) {
        await new Promise((resolve) => watch(walletProvider, resolve))
    }
    const provider = new ethers.BrowserProvider(walletProvider.value)
    const signer = await provider.getSigner()
    const contract = await getContract()
    availableAmount.value = parseFloat(ethers.formatEther(await contract.getAvailableAmount(signer.address)))
    tokenPrice.value = parseFloat(ethers.formatEther(await contract.price()))
    tokenAddress.value = await contract.token();
    getBalance()
    getTokenBalance()
}
init()

const ethError = computed(() => {
    if (ethValue.value > walletBalance.value) {
        return 'Not enough ETH'
    }
    // if(ethValue.value <= 0) return 'ETH should be more than 0'
    return false
})
const tokenError = computed(() => {
    if (tokenValue.value > availableAmount.value) {
        return 'You can buy maximum ' + availableAmount.value + ' tokens'
    }
    return false
})
const buyDisabled = computed(() => {
    return !!ethError.value || !!tokenError.value || ethValue.value <= 0
})
const toast = useToast()
const buy = async () => {
    isLoading.value = true
    try {
        const contract = await getContract()

        await contract.buy({ value: BigInt(parseFloat(ethValue.value) * 1e18) })

        toast.add({ title: `Successfully bought ${tokenValue.value} ${config.tokenSymbol}`, color: 'green' })
    } catch (err) {
        toast.add({ title: `Couldn't buy tokens: ${err.reason}`, color: 'red' })

        console.log(err)
    }
    isLoading.value = false
    init()

}
const withdraw = async () => {
    const contract = await getContract()
    await contract.withdrawTokens(BigInt(19799 * 1e18))
}
const withdrawEth = async () => {
    const contract = await getContract()
    await contract.withdrawEth()
}
const setPrice = async () => {
    const contract = await getContract()
    await contract.setPrice(BigInt(parseFloat(value.value) * 1e18))
}
</script>