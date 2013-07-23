json.array!(@estatuses) do |estatuse|
  json.extract! estatuse, 
  json.url estatuse_url(estatuse, format: :json)
end