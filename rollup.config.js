import resolve from '@rollup/plugin-node-resolve';
import typescript from "@rollup/plugin-typescript";
import commonjs from "@rollup/plugin-commonjs";


module.exports = [
    {
        input: [
            'src/node-test.ts'
        ],
        output: {
            file: 'build/node-test.js',
            format: 'cjs',
            sourcemap: true
        },
        plugins: [
            typescript(),
            commonjs()
        ]
    },
    {
        input: [
            'src/js/main.ts'
        ],
        output: {
            file: 'build/js/main.js',
            format: 'esm',
            sourcemap: true,
            preserveEntrySignatures: 'allow-extension'
        },
        treeshake: false,
        plugins: [
            resolve(),
            typescript()
        ]
    }
]

