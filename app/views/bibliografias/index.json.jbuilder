json.array!(@bibliografias) do |bibliografia|
  json.extract! bibliografia, 
  json.url bibliografia_url(bibliografia, format: :json)
end