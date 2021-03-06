module Cryptoexchange::Exchanges
  module BtcTradeUa
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super(ticker_url)
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::BtcTradeUa::Market::API_URL}/ticker"
        end

        def adapt_all(output)
          output.map do |pair, ticker|
            next if pair == 'status'
            base, target = pair.split('_')
            market_pair  = Cryptoexchange::Models::MarketPair.new(
              base:   base,
              target: target,
              market: BtcTradeUa::Market::NAME
            )
            adapt(ticker, market_pair)
          end.compact
        end

        def adapt(output, market_pair)
          ticker        = Cryptoexchange::Models::Ticker.new
          ticker.base   = market_pair.base
          ticker.target = market_pair.target
          ticker.market = BtcTradeUa::Market::NAME
          ticker.ask       = NumericHelper.to_d(output['sell'])
          ticker.bid       = NumericHelper.to_d(output['buy'])
          ticker.high      = NumericHelper.to_d(output['high'])
          ticker.low       = NumericHelper.to_d(output['low'])
          ticker.last      = NumericHelper.to_d(output['last'])
          ticker.volume    = NumericHelper.to_d(output['vol'])
          ticker.timestamp = NumericHelper.to_d(output['updated'])
          ticker.payload   = output
          ticker
        end
      end
    end
  end
end
