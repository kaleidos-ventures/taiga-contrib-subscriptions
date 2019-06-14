###
# Copyright (C) 2014-2019 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: lightbox-contact-us.directive.coffee
###

module = angular.module('subscriptions')

LightboxContactUsDirective = (lightboxService) ->
    return {
        scope: {},
        bindToController: true,
        controller: 'ContribLbContactUsController',
        controllerAs: 'vm',
        templateUrl: 'compile-modules/taiga-contrib-subscriptions/components/lb-contact-us/lightbox-contact-us.html',
    }

LightboxContactUsDirective.$inject = [
    "lightboxService"
]

module.directive("tgLbContactUs", LightboxContactUsDirective)
