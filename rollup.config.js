import resolve from '@rollup/plugin-node-resolve';
import typescript from "@rollup/plugin-typescript";
import commonjs from "@rollup/plugin-commonjs";


module.exports = [
    {
        input: [
            'deploy-script.ts'
        ],
        output: {
            file: 'deploy-script.cjs',
            format: 'cjs',
            sourcemap: true
        },
        plugins: [
            typescript()
        ]
    },
]

