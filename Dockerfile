##
# Copyright IBM Corporation 2016, 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# Builds a Docker image with all the dependencies for compiling and running the Kitura-Starter sample application.

FROM ibmcom/swift-ubuntu:4.0.3
MAINTAINER IBM Swift Engineering at IBM Cloud
LABEL Description="Docker image for building and running noque-server"

# Expose default port for Kitura
EXPOSE 8080

RUN mkdir /server

ADD Sources /server/Sources
ADD Tests /server/Tests
ADD public /server/public
ADD Package.swift /server
ADD Package.resolved /server
ADD LICENSE /server
ADD .swift-version /server
RUN cd /server && swift build

#CMD ["/server/.build/debug/noque-server"]
CMD [ "sh", "-c", "cd /server && ./.build/x86_64-unknown-linux/release/noque-server" ]
