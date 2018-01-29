require "http"
require "json"

module Jikan
  class API

    def initialize(use_ssl=true)
			@endpoint = ""
			@id = nil
			@ext = nil
			@selected_base = if use_ssl then Jikan::BASE_URL_SSL else Jikan::BASE_URL end
		end

		def get(endpoint, id, ext=nil, qry='')
			@endpoint = endpoint
			@id = id
			@ext = ext
      @query = qry

			construct_url
			get_data
		end

    private

		def construct_url
			@end_url = "#{@selected_base}/#{@endpoint}"
      @url = "#{@end_url}/#{@id}"

      if @endpoint.eql?('search')
				unless Jikan::FLAGS[@endpoint].include? @ext
					raise Jikan::ExtensionError, 'Extensions not supported'
				else
					@url = "#{@end_url}/#{@ext.to_s}/#{@query}/#{@id}"
				end
      end

			unless @ext.nil? || @endpoint.eql?('search')
				unless Jikan::FLAGS[@endpoint].include? @ext
					raise Jikan::ExtensionError, 'Extensions not supported'
				end
				@url << "/#{@ext.to_s}"
			end
		end

		def get_data
			res = HTTP.get(@url)
			if res.status >= 400
				raise ClientError, "#{res.status}: error on endpoint #{@endpoint}"
			end

			JSON.parse(res.body)
		end
  end
end