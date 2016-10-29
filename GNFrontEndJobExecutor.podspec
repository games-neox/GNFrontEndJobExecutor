#
#  Created by Games Neox - 2016
#  Copyright © 2016 Games Neox. All rights reserved.
#

Pod::Spec.new do |s|
s.name                  = 'GNFrontEndJobExecutor'
s.version               = '0.1.0'
s.summary               = 'Simple (yet powerful & flexible) Job Executor for Objective-C'

s.homepage              = 'https://github.com/games-neox/GNFrontEndJobExecutor'
s.license               = { :type => 'MIT', :file => 'LICENSE' }
s.author                = { 'Games Neox' => 'games.neox@gmail.com' }
s.source                = { :git => 'https://github.com/games-neox/GNFrontEndJobExecutor.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'

s.dependency 'GNExceptions'
s.dependency 'GNLog'
s.dependency 'GNPreconditions'
s.dependency 'GNThreadPool'

s.source_files          = 'GNFrontEndJobExecutor/Classes/*'

s.public_header_files   = 'GNFrontEndJobExecutor/Classes/*.h'
end
