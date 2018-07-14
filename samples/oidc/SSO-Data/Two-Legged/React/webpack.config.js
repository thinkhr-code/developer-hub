const webpack = require('webpack');
const HtmlWebPackPlugin = require("html-webpack-plugin");
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  mode: 'production',
  watch: true,
  entry: ['babel-polyfill', './src/index.js'],
  devtool: 'source-map',
  resolve: {
    extensions: ['.js', '.json', '.jsx', '.css', '.scss'],
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.(png|jpg|gif)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192,
            },
          },
        ],
      },
    ],
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "./src/index.html",
      filename: "./index.html",
    }),
    new webpack.DefinePlugin({
      clientId: JSON.stringify(process.env.clientId),
      clientSecret: JSON.stringify(process.env.clientSecret),
      baseUrl: JSON.stringify(process.env.baseUrl),
    }),
  ],
};
