#
# Be sure to run `pod lib lint CVFRCDelegate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CVFRCDelegate'
  s.version          = '0.1.0'
  s.summary          = 'Fix for using UICollectionView with NSFetchedResultsController'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
If you've ever used NSFetchedResultsController with a UITableView, you know how awesome it can be. However try using it with a UICollectionView and you will inevitably find yourself facing heartache and frustration.
                       DESC

  s.homepage         = 'https://github.com/jzucker2/CVFRCDelegate'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jzucker2' => 'jordan.zucker@gmail.com' }
  s.source           = { :git => 'https://github.com/jzucker2/CVFRCDelegate.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jzucker'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CVFRCDelegate/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CVFRCDelegate' => ['CVFRCDelegate/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreData'
  # s.dependency 'AFNetworking', '~> 2.3'
end
