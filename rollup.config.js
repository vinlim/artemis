import resolve from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';
import typescript from "@rollup/plugin-typescript";

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
            resolve(),
            typescript(),
            terser()
        ]
    }
]

