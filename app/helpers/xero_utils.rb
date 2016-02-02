module XeroUtils
	def xero_client
		logger = Logger.new('log/xero.log', 'daily')
    Xeroizer::PrivateApplication.new(ENV['XERO_API_KEY'], ENV['XERO_SECRET'], '| echo "$XERO_PRIVATE_KEY" ', :logger => logger)
  end
end
