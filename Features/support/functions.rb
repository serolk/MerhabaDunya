#encoding: UTF-8

def portNo
  return 7005
end
require 'rspec'
def tokenYarat(portNumber)
  url="http://tstfinidsrv.zb:#{portNumber}/connect/token"
  body={
      "grant_type"=>"password",
      "client_id"=>"anahtar.ui",
      "client_secret"=>"yetkin",
      "username"=>"OHALICI",
      "password"=>"NP321",
      "ClientIp"=>"10.75.4.7",
      "BranchId"=>-1,
      "ChannelId"=>-2,
      "IsUnlock"=>false,
      "WindowsDomainName"=>-1,
      "WindowsHostName"=>-2,
      "WindowsUserName"=>-3
  }
  header={"Content-Type"=>"application/x-www-form-urlencoded"}
=begin
url="http://ztwallidsrv01:#{portNumber}/connect/token"
  body={
        :grant_type=>"password",
        :client_id=>"anahtar.ui",
        :client_secret=>"yetkin",
        :username=>"FINTEKSG",
        :password=>"NP321"
  }
=end
  response=RestClient.post url,body,header
  token=JSON.parse response
  # puts token['access_token']
  return token['access_token']
end



=begin

def cevirEscape url
 index=url.index(":",5)
 string1=url[0..index]
 string2= url[index+1..-1]
 string2.gsub!(/[{}:' %\[\]"]/,"{"=>"%7B","}"=>"%7D",":"=>"%3A","'"=>"%27"," "=>"%20","%"=>"%25","["=>"%5B","]"=>"%5D","\""=>"%22")
 return string1+string2
end

=end

def cevirEscape url
  index=url.index(":",5)
  string1=url[0..index]
  string2= url[index+1..-1]
  # puts index
  # puts string1
  # puts string2
  string2.gsub!(/[{}:' %\[\]ıü]/,'{'=>'%7B','}'=>'%7D',':'=>'%3A',"'"=>'%27',' '=>'%20','%'=>'%25','['=>'%5B',']'=>'%5D','\''=>'%22','ı'=>'%C4%B1','ü'=>'%C3%BC')
  return string1+string2
end

def valid_json?(json)
  begin
    JSON.parse(json)
    return true
  rescue Exception => e
    return false
  end
end



def dbSorgula query
  cursor = $db_connection.exec( query )
  urun = Array .new

  while r = cursor.fetch
    urun.push r[0]
    # puts r.join(",")
  end

  return urun
end

def dbSorgulaTablo query
  cursor = $db_connection.exec( query )
  urun = Array .new

  while r = cursor.fetch
    urun.push r
    # puts r.join(",")
  end
  return urun
end


def dbDegistir ortam

  if ortam == 'qa'
    database={
        "user"     => "finarttest",
        "password" => "fin1art2test3",
        "url"      => "10.1.21.27:1536/TEST"
    }
  elsif ortam == 'qafa'
    database={
        "user"     => "sorgu",
        "password" => "sorgu1",
        "url"      => "10.11.208.129:1521/fadbtEST"
    }
  elsif ortam == 'dev'
    database={
        "user"     => "finartytl",
        "password" => "f2n6rtytl",
        "url"      => "10.1.21.26:1526/O10G"
    }

  end
  # puts $database["user"] + "|" + $database["password"] + "|" + $database["url"]
  # puts "dbDegistir"
  $db_connection = OCI8.new(database["user"],database["password"],database["url"])

end


def dbSilveyaGuncelle sqlcommand
  cursor = $db_connection.exec(sqlcommand)
  $db_connection.commit
  # $db_connection .logoff
end

def header
  return getHeader(7005)
end

def getHeader(portNumber)
  header = {"Content-Type"=>"application/json; charset=utf-8",
            "Authorization"=>"Bearer #{tokenYarat(portNumber)}",
            "CallerInfo"=>"{'ChannelId':23,'BankId':5004,'BranchType':'B','BranchId':5004,'UserName':'OBILICI','ScreenId':'XXXXXXXX','ScreenVersion':'','ComputerName':'ZT1199W01','BranchCountryId':'hjk','CurrentDate':'','CallId':1,'ADUserName':'undefined','SessionInfo':null,'CommandInfo':null,'ScreenOpeningMode':'','ZfuContext':null}"
  }
  return header
end

def getHeaderSpecificForApprove(portNumber, approvementRef, screenId)

  cursor = $db_connection.exec "SELECT d.branch_cd, d.group_cd FROM fla_approvementstep d where d.approvement_ref = '#{approvementRef}' ORDER BY d.steporder desc"

  veriler = Array.new
  r = cursor.fetch
  veriler.push r[0].to_i
  # puts veriler[0]
  veriler.push r[1].to_i
  # puts veriler[1]


  subeTipi = "S"
  if veriler[0] > 5000
    subeTipi = "B"
  end

  cursor = $db_connection.exec "SELECT k.yet_kullanici_kod
  FROM yet_kullaniciningruplari k
  JOIN yet_kullanici yy
    ON yy.yet_kullanici_kod = k.yet_kullanici_kod
 WHERE k.yet_kullanici_kod IN (SELECT y.yet_kullanici_kod
                                 FROM yet_kullanici y
                                WHERE y.yet_kullanici_kod IN (SELECT yg.yet_kullanici_kod
                                                                FROM yet_kullaniciningruplari yg
                                                               WHERE yg.yet_grup_kod IN (SELECT df.yet_grup_kod
                                                                                           FROM YET_GRUPLARINEKRANYETKILERI df
                                                                                           JOIN yet_kullaniciningruplari yg
                                                                                             ON df.yet_grup_kod = yg.yet_grup_kod
                                                                                          WHERE df.yet_ekran_kod = '#{screenId}'))
                                  AND y.yet_kullanici_drm = 'A'
                                  AND ((#{veriler[0]} > 5000 AND y.yet_birim = #{veriler[0]}) OR (#{veriler[0]} < 5000 AND y.yet_sube = #{veriler[0]}))
                                  AND k.yet_grup_kod = #{veriler[1]})"

  r = cursor.fetch

  while r = cursor.fetch
    if r[0].to_s != "MBUGDAY"
      veriler.push r[0].to_s
      puts veriler[0]
      break
    end
  end
  puts r[0]
  kullaniciKod = r[0].to_s

  return getHeaderSpecific(portNumber, veriler[0], subeTipi, screenId, 23, kullaniciKod)

end

def getHeaderSpecific(portNumber, branchId, branchType, screenId, channelId, userKod)

  if (userKod != nil and userKod.length > 0)
    kullaniciAdi = userKod
  else
    kullaniciAdi = "OBILICI"
  end
  if (branchId != nil and branchId.to_s.length > 0)
    subeNo = branchId
  else
    subeNo = 5004
  end
  if (branchType != nil and branchType.length > 0)
    subeTip = branchType
  else
    subeTip = "B"
  end
  if (screenId != nil and screenId.length > 0)
    ekranKod = screenId
  else
    ekranKod = "XXXXXXXX"
  end
  if (channelId != nil and channelId.to_s.length > 0)
    kanalNo = channelId
  else
    kanalNo = 23
  end
  header = {"Content-Type"=>"application/json; charset=utf-8",
            "Authorization"=>"Bearer #{tokenYarat(portNumber)}",
            "CallerInfo"=>"{'ChannelId':#{kanalNo},'BankId':10,'BranchType':'#{subeTip}','BranchId':#{subeNo},'UserName':'#{kullaniciAdi}','ScreenId':'#{ekranKod}','ScreenVersion':'','ComputerName':'ZT1199W01','BranchCountryId':'TR','CurrentDate':'','CallId':1,'ADUserName':'undefined','SessionInfo':null,'CommandInfo':null,'ScreenOpeningMode':'','ZfuContext':null}"
  }
  puts header
  return header
end

def sendGetRequestNoParse url,header
  url2=cevirEscape url
  begin
    response = RestClient.get  url2,header
  rescue Exception => e
    puts url
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end
  expect(response.code).to eq 200
end

def sendGetRequest url,header

  begin
    urlC=cevirEscape url
    response = RestClient.get urlC,header
  rescue Exception => e
    puts "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    puts url
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end
  expect(response.code).to eq 200
  if valid_json? response
    response=JSON.parse response
  else
    puts "JSON değil, parse edilemedi"
  end
  # ***************************************************
  # JSON PARSE ve GENERATE birbirinin tam tersi iş yapar.
  # my_hash = JSON.parse '{"hello": "goodbye"}'
  # puts my_hash
  # puts JSON.generate(my_hash)
  # puts my_hash
  # puts my_hash.to_json #### TO_JSON İFADESİ JSON.GENERATE İLE AYNI İŞİ YAPAR
  # ***************************************************
    return response
  # puts (response.code)
  # if response.code!= 200
  # #   # puts response["exception"]["MTitle"] +" : "+response["exception"]["MErrorDescription"]
  # #   # puts "HATA! \n" + response["exception"].to_s
  #   puts "Response Status Hatalı. Response Code: "+(response.code).to_s
  # end
end


def createTableFromResponseKeys response
   getResponseBody(response).each_key {|key| puts "|#{key}|"}
   # getResponseBody(response).keys.each {|hash| puts hash}
end



def sendDeleteRequest url,header
  url2=cevirEscape url
  begin
    response = RestClient.delete url2,header
  rescue Exception => e
    puts "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    puts url
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end
  expect(response.code).to eq 200
  if valid_json? response
    response=JSON.parse response
  else
    puts "JSON değil, parse edilemedi"
  end

  return response
  # if response['statusCode']!= 200
  #   # puts response["exception"]["MTitle"] +" : "+response["exception"]["MErrorDescription"]
  #   puts "HATA! \n" + response["exception"].to_s
  # end
  # expect(response['statusCode']).to eq 200
end

def getResponseBody response
  if response.is_a?(Array)   #is_a?(class) fonk. yerine kindof?(class) fonksiyonu da kullanılabilir.
    return response[0]       # dönen sonuç bir dizi ise diziden çıkartmak için dizinin ilk elemanı response kabul edilir
  else
    return response
  end
end

def sendPostRequest url,body,header
  url2 = cevirEscape url

  if valid_json? body
    begin
      response = RestClient.post url2,body, header
      puts "Post Request is successfull"
    rescue Exception => e
      puts "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      puts url
      puts body
      puts "Status: " + e.to_s
      puts e.http_body
      raise()
    end
  else
    begin
      puts "else case body:" + body.to_json.to_s
      puts "else case url:" + url2
      puts "else case header:" + header
      response = RestClient.post url2,body.to_json, header
      puts "Post Request is successfull"
    rescue Exception => e
      puts "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      puts url
      puts body.to_json
      puts "Status: " + e.to_s
      puts e.http_body
      raise()
    end
  end

  # response = RestClient.post url,body.to_json, header
  # puts response
  expect(response.code).to eq 200
  # puts eval(response.code.to_s)
  if valid_json? response
    response=JSON.parse response
  else
    puts "JSON değil, parse edilemedi"
  end

  return response
  # response=JSON.parse response
  # if response['statusCode']!= 200
  #   # puts response["exception"]["MTitle"] +" : "+response["exception"]["MErrorDescription"]
  #   puts "HATA! \n" + response["exception"].to_s
  # end
  # expect(response['statusCode']).to eq 200
end

def sendPutRequest url,body,header
  url2=cevirEscape url
  begin
    response = RestClient.put url2,body.to_json,header
  rescue Exception => e
    puts "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    puts url
    puts body.to_json
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end

  expect(response.code).to eq 200
  if valid_json? response
    response=JSON.parse response
  else
    puts "JSON değil, parse edilemedi"
  end
# rescue
#   puts "JSON değil, parse edilemedi"
# ensure
  return response
  # response=JSON.parse response
  # if response['statusCode']!= 200
  #   # puts response["exception"]["MTitle"] +" : "+response["exception"]["MErrorDescription"]
  #   puts "HATA! \n" + response["exception"].to_s
  # end
  # expect(response['statusCode']).to eq 200
end

def checkGetResponse kontroldizi,url,header
  dizikontrol=Array.new
  kontroldizi.each { |item| dizikontrol.push item[0].downcase }
  begin
    response=getResponseBody(sendGetRequest url,header)
  rescue Exception => e
    puts url
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end
  # puts response
  expect(response).not_to be_empty
  # expect(response).not_to eq []
  responsedizi=Array.new
  response.each_key { |key| responsedizi.push key.downcase}
  expect(dizikontrol-responsedizi).to eq [] # Response dizi table^daki alanların tümünü içeriyorsa sonuç boş dizi olmalıdır.
  count=0
  response.values.each { |val| count+=1 if val!=nil and val!="" } # Response value değerlerinin tamamı null ya da boş olmamalı
  expect(count).to be >=1 # Donen value değerlerinden en az birkaçı null olmammalı
  return response
end

# Bu motod  yanlızca verilen tablo ile dönen response un key değerlerini kontrol eder, value lara bakmaz
def checkResponseKeys kontroldizi,url,header
  dizikontrol=Array.new
  kontroldizi.each { |item| dizikontrol.push item[0].downcase }
  response=getResponseBody(sendGetRequest url,header)
  # puts response
  expect(response).not_to be_empty
  # expect(response).not_to eq []
  responsedizi=Array.new
  response.each_key { |key| responsedizi.push key.downcase}
  expect(dizikontrol-responsedizi).to eq [] # Response dizi table^daki alanların tümünü içeriyorsa sonuç boş dizi olmalıdır.
  return response
end

def checkPostResponse kontroldizi,url,body,header
  dizikontrol=Array.new
  kontroldizi.each { |item| dizikontrol.push item[0].downcase }
  begin
    response=getResponseBody(sendPostRequest url,body,header)
  rescue Exception => e
    puts url
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end
  expect(response).not_to be_empty
  # expect(response).not_to eq []
  responsedizi=Array.new
  response.each_key { |key| responsedizi.push key.downcase}
  expect(dizikontrol-responsedizi).to eq [] # Response dizi table^daki alanların tümünü içeriyorsa sonuç boş dizi olmalıdır.
  count=0
  response.values.each { |val| count+=1 if val!=nil and val!="" } # Response value değerlerinin tamamı null ya da boş olmamalı
  expect(count).to be >=1 # Donen value değerlerinden en az birkaçı null olmammalı
  return response
end


# index=url.index(":",5)
# portNumber=url[index+1..4]

def checkGetResponseByParam kontroldizi,url,header,parametre
  dizikontrol=Array.new
  # puts kontroldizi
  kontroldizi.each { |item| dizikontrol.push item[0].downcase }
  begin
    response=getResponseBody(sendGetRequest url,header)["#{parametre}"]
  rescue Exception => e
    puts url
    puts "Status: " + e.to_s
    puts e.http_body
    raise()
  end
  # puts response
  responsedizi=Array.new
  if response.is_a?(Array)   #is_a?(class) fonk. yerine kindof?(class) fonksiyonu da kullanılabilir.
    puts response.length
    if response.length>0
      paramValue=response[0]
    else
      puts "servis #{parametre} alt değerlerini getirmedi"
      return "#{parametre} response boş"
    end
  else
    paramValue=response
  end
  paramValue.each_key { |key| responsedizi.push key.downcase}# dönen sonuç bir dizi ise diziden çıkartmak için dizinin ilk elemanı response kabul edilir
=begin
   puts dizikontrol
   puts responsedizi
=end
  expect(dizikontrol-responsedizi).to eq [] # Response dizi table^daki alanların tümünü içeriyorsa sonuç boş dizi olmalıdır.
  count=0
  paramValue.values.each { |val|  count+=1 if val!=nil and val!="" } # Response value değerlerinin tamamı "" ya da boş olmamalı
  expect(count).to be >=1 # Donen value değerlerinden en az birkaçı "" olmammalı
end


def compareResponseWithTable kontroldizi,response
  dizikontrol=Array.new
  kontroldizi.each { |item| dizikontrol.push item[0].downcase }
  expect(response).not_to be_empty
  # expect(response).not_to eq []
  responsedizi=Array.new
  response.each_key { |key| responsedizi.push key.downcase}
  expect(dizikontrol-responsedizi).to eq [] # Response dizi table^daki alanların tümünü içeriyorsa sonuç boş dizi olmalıdır.
  count=0
  response.values.each { |val| count+=1 if val!=nil and val!="" } # Response value değerlerinin tamamı null ya da boş olmamalı
  expect(count).to be >=1 # Donen value değerlerinden en az birkaçı null olmammalı
  return response
end



