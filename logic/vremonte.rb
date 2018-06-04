# encoding: UTF-8
require_relative '../system/bot_log'

module Vremonte
  # $https = false

  def initialize_sender(msisdn, pattern_url, method, portal_id)
    uri = URI.parse($url_pmc + portal_id + pattern_url)

    http = Net::HTTP.new(uri.host, uri.port)
    # only for prod system
    # http.use_ssl = $https

    if method == 'Get'
      req = Net::HTTP::Get.new(uri, initheader = {'Content-Type' => 'application/x-www-form-urlencoded',
                                                  'X-Channel-Id' => $x_channel_id,
                                                  'X-IV-Authorization' => 'Identifier '+msisdn})
    else
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/x-www-form-urlencoded',
                                                        'X-Channel-Id' => $x_channel_id,
                                                        'X-IV-Authorization' => 'Identifier '+msisdn})
    end

    return http, req
  end

end