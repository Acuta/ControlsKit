Pod::Spec.new do |s|
  s.name             = 'ControlsKit'
  s.version          = '1.0.0'
  s.summary          = 'A collection of battle-tested UI components.'

  s.description      = <<-DESC
			This is a list of components that have been developped over the course of multiple years, and have been used in a dozen of projects so far. They aim to either be a drop-in replacement for existing controls with more customizations, or provide additional features on top of existing controls.
                       DESC

  s.homepage         = 'https://github.com/Acuta/ControlsKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'stephanecopin' => 'stephane.copin@live.fr', 'bastienFalcou' => 'bastien.falcou@hotmail.com' }
  s.source           = { :git => 'https://github.com/Acuta/ControlsKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.exclude_files = 'ControlsKit/ControlsKit.h'

	s.default_subspecs = 'Swift'

	subspecs = [
		'NibView',
		'PlaceholderTextView',
		'PageControl',
		'Switch',
		'PageViewController',
	]

	['ObjC', 'Swift'].each do |lang|
		s.subspec lang do |ss|
			subspecs.each do |name|
				ss.dependency "ControlsKit/#{name}/#{lang}"
			end
		end
	end

	subspecs.each do |name|
		s.subspec name do |ss|
			ss.subspec 'ObjC' do |sss|
				sss.source_files = "ControlsKit/CTK#{name}.{h,m}"
			end
			ss.subspec 'Swift' do |sss|
				sss.dependency "ControlsKit/#{name}/ObjC"
				sss.source_files = "ControlsKit/#{name}.swift"
			end
		end
	end
end
