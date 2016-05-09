#
# Be sure to run `pod lib lint LBNCoreDataStack.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LBNCoreDataStack"
  s.version          = "0.1.3"
  s.summary          = "Remove all Core Data template methods from AppDelegate and use this to access those methods from anywhere in your project in a neat way."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Substitute Core Data methods from AppDelegate and encapsulates it in its own class. This class is accessible as a singleton from sharedStack method.
Also available a persistence class to handle most of the more common operetions as insert and delete from CoreData.
                       DESC

  s.homepage         = "https://github.com/sciasxp/LBNCoreDataStack"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Luciano Bastos Nunes" => "sciasxp@gmail.com" }
  s.source           = { :git => "https://github.com/sciasxp/LBNCoreDataStack.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'LBNCoreDataStack' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'LBNTools', '~> 0.0'
end
