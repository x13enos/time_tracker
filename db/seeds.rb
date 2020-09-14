# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

workspace = Workspace.create(name: "default")
user = User.new(email: "owner@gmail.com", active_workspace_id: workspace.id, name: "Owner")
user.password = 'password'
user.save
workspace.users << user
user.users_workspaces.last.update(role: UsersWorkspace.roles["owner"])
