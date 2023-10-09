const webpack = require('webpack');

const path = require('path');

const ExtractTextPlugin = require('extract-text-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const fs = require('fs')

var devServerPort = process.env.WEBPACK_DEV_SERVER_PORT,
    devServerHost = process.env.WEBPACK_DEV_SERVER_HOST,
    publicPath = process.env.WEBPACK_PUBLIC_PATH;

const env = process.env.NODE_ENV

const config = {
    mode: env || 'development',
    
    entry: {
        app: [
            './app/assets/javascript/slice_includes.generated-fe.js',
            './app/assets/javascript/application.js'
        ],
        be: [
            './app/assets/javascript/slice_includes.generated-be.js'
        ],
    },

    output: {
        path: path.resolve(__dirname + '/media/public/assets'),
        filename: 'bundle-[name].js',
        publicPath: 'auto'
    },

    resolve: {
        symlinks: false,
        alias: {
        //'vue$': 'vue/dist/vue.esm.js'
        }
    },
    optimization: {
        minimizer: [
            new UglifyJsPlugin({
                cache: true,
                parallel: true,
                sourceMap: true, // set to true if you want JS source maps
                extractComments: true,
            }),
            new OptimizeCSSAssetsPlugin({})
        ]
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            }
            ,
            {
                test: /\.sass|\.css$/,
                use: [
                    // fallback to style-loader in development
                    process.env.NODE_ENV !== 'production' ? 'style-loader' : MiniCssExtractPlugin.loader,
                    "css-loader",
                    "sass-loader"
                ]
            }

        ]
    }
    , plugins: [
        new MiniCssExtractPlugin({
            filename: "screen-[name].css",
            chunkFilename: "[name].css"
        })
        ,
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery"
        })
    ]
};

module.exports = config
