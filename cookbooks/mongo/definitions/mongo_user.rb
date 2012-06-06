define :mongo_user do
  execute "mongo #{params[:name]} --eval 'db.addUser(\"#{params[:user]}\", \"#{params[:password]}\")'"
end
