# Health2Fitbit

Health2Fitbit is a simple tool that continiously transfers steps recorded in HealthKit (for example from Apple Watch or iPhone) to Fitbit.

#Installation

In order to install Health2Fitbit on your device, you'll have to create your own Fitbit Application on https://dev.fitbit.com:

In order to do this, you'll need to:

1. Go to https://dev.fitbit.com/apps/new
2. Fill form with your app name, description, etc.

Health2Fitbit uses oAuth 1.0 authentication, make sure that "Browser" type is selected there. Also provide "read + write" access to fitbit data.

3. Copy your *Client (Consumer) Key* and *Client (Consumer) Secret*, and fill them in constructor of *H2FHealthManager* class.
4. Build app, and deploy it on your iOS device.

#Usage

After launching the app, tap "login" button, and provide read access to HealthKit steps, and type correct credentials to Fitbit. Right after that, app run in the background, you won't even need to launch it again!

# How it works?

Because Fitbit isn't providing any API's for adding steps, I'm using a little hack here - app is posting steps as separate "Walking" activities. One activity for each hour in a day. 

More or less every hour, when HealthKit detects change in steps count, Health2Fitbit app is launched in the background. After this, app is looking at activities that are already uploaded to Fitbit, even on those that were uploaded 7 days in the past. All differences between steps count on Fitbit and steps count in HealthKit are transferred to Fitbit.


# LICENSE

The MIT License (MIT)

Copyright (c) 2015 Michał Mizera

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.