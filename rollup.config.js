require('source-map-support').install();

import resolve from '@rollup/plugin-node-resolve';
import typescript from "@rollup/plugin-typescript";
import commonjs from "@rollup/plugin-commonjs";


module.exports = [
    {
        input: [
            'src/index.ts',
        ],
        output: {
            file: 'build/index.js',
            format: 'cjs',
            sourcemap: true
        },
        plugins: [
            typescript()
        ]
    }
]

