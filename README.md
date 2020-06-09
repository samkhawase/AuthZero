# AuthZero
AuthZero integration with Postgrest. 
This is part of the [blog series](https://samkhawase.com/blog/postgrest) about PostgREST API tutorial, and it's integration with Auth0. 

## Getting Started

Here are the steps to get started with the project on your local machine:
1. Clone the git repositiory
2. Run `carthage update --platform iOS --cache-builds --no-use-binaries` to fetch the dependencies.
3. Run the project via Xcode.

### Prerequisites

What things you need to install the software and how to install them

1. Mac OS X
2. Xcode 9
3. [Carthage](https://github.com/Carthage/Carthage) 
4. Optional: [xcpretty](https://github.com/supermarin/xcpretty)

## Auth0 Integration
Add the _Client ID_ and _Domain name_ in the `Auth0.plist` of the iOS app. You can find these values in the Auth0 Dashboard.

## Building the app

To build the app, enter the command on the command line.
```
xcodebuild -scheme 'AuthZero' \                                                                                                              3744ms  Wed Mar 18 16:10:48 2020
    -sdk iphonesimulator \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' \
    clean build | xcpretty
```

The output will be similar to:
```
▸ Clean Succeeded
▸ Compiling ViewController.swift

⚠️  ~/AuthZero/AuthZero/ViewController.swift:51:17: immutable value 'roles' was never used; consider replacing with '_' or removing it
            let roles = jwt.claim(name: "https://postgrest-demo.de/role").array
                ^~~~~
▸ Compiling AppDelegate.swift
▸ Compiling SceneDelegate.swift
▸ Linking AuthZero
▸ Copying Auth0.plist
▸ Compiling Main.storyboard
▸ Compiling LaunchScreen.storyboard
▸ Processing Info.plist
▸ Running script 'Run Script'
▸ Touching AuthZero.app (in target 'AuthZero' from project 'AuthZero')
▸ Build Succeeded
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
