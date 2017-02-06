project 'RFSVG.xcodeproj'
platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod "RFSVG", :path => "."
end

target "RFSVG" do
    shared_pods
end

target "Example" do
    shared_pods
end

target "RFSVGTests" do
    shared_pods
    
    pod "FBSnapshotTestCase"
    pod "SMWebView"
end
