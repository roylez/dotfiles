# Sample Maid rules file -- some ideas to get you started.
#
# To use, remove ".sample" from the filename, and modify as desired.  Test using:
#
#     maid clean -n
#
# **NOTE:** It's recommended you just use this as a template; if you run these rules on your machine without knowing
# what they do, you might run into unwanted results!
#
# Don't forget, it's just Ruby!  You can define custom methods and use them below:
# 
#     def magic(*)
#       # ...
#     end
# 
# If you come up with some cool tools of your own, please send me a pull request on GitHub!  Also, please consider sharing your rules with others via [the wiki](https://github.com/benjaminoakes/maid/wiki).
#
# For more help on Maid:
#
# * Run `maid help`
# * Read the README, tutorial, and documentation at https://github.com/benjaminoakes/maid#maid
# * Ask me a question over email (hello@benjaminoakes.com) or Twitter (@benjaminoakes)
# * Check out how others are using Maid in [the Maid wiki](https://github.com/benjaminoakes/maid/wiki)

Maid.rules do
  # **NOTE:** It's recommended you just use this as a template; if you run these rules on your machine without knowing
  # what they do, you might run into unwanted results!

  # rule '手机上超过30天的图片' do
  #   dir([
  #     '/backup/media/roy_phone/camera/Camera/*.jpg', 
  #     '/backup/media/roy_phone/sharedit/*.jpg',
  #     '/backup/media/roy_phone/wechat/*.jpg',
  #     ]).select { |f|
  #     move(f, '/backup/media/roy_phone/camera/next_to_move/') if 30.day.since?(created_at(f))
  #   }
  #
  # end
  #
  # rule '手机上没用的小文件' do
  #   dir('/backup/media/roy_phone/camera/next_to_move/*').each do |f|
  #     remove(f) if disk_usage(f) < 1024
  #   end
  # end
  #
  # rule '手机上需要备份的图片' do
  #   cmd('exiftool "-Filename<DateTimeOriginal" -d "/backup/media/album/%Y/%Y-%m-%d/%Y%m%d_%H%M%S%%-c.%%e" /backup/media/roy_phone/camera/next_to_move')
  # end

end
