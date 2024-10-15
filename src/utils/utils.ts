export default class Utils {
    static truncateAddress(string, startLength = 6, endLength = 6) {
        if (string.length > startLength + endLength) {
            const startString = string.substring(0, startLength);
            const endString = string.substring(string.length - endLength);
            return `${startString}...${endString}`;
        }
        return string;
    }

    static getAptosWallet() {
        if ('aptos' in window) {
            return window.aptos;
        } else {
            window.open('https://petra.app/', `_blank`);
        }
    };
}
