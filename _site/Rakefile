task :default => [:compile_js]

task :compile_js do
  scripts = Dir["jslib/*.js"]
  content = ""
  scripts.each do |script|
    content += "\n" + File.read(script)
  end
  File.write("assets/lib.js", content)
  puts "Compiled JS assets from jslib to public/assets/lib.js"
end
