import {defineStore} from 'pinia'

export const useWalletStore = defineStore('walletStore', {
    state: () => ({
        address: null,
        publicKey: null,
        connected: false
    }),

    actions: {
        connect(wallet) {
            this.address = wallet.address;
            this.publicKey = wallet.publicKey;
            this.connected = true;
        },
        disconnect() {
            this.address = null
            this.publicKey = null;
            this.connected = false;
        }
    }
})
