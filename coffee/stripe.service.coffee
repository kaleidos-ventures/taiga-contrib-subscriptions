###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: stripe.service.coffee
###

module = angular.module('subscriptions')

class ContribStripeService
    @.$inject = ["$tgConfig"]

    constructor: (@config) ->

    start: (options) ->
        @.stripeHandler = null


        ljs.load "https://checkout.stripe.com/checkout.js", =>
            options.onLoad()

            key = @config.get("stripeKey")

            image = "/#{window._version}/images/taiga-contrib-subscriptions/images/#{options.plan.toLowerCase()}.png"
            @.stripeHandler = StripeCheckout.configure({
                key: key,
                image: image,
                locale: 'auto',
                billingAddress: true,
                panelLabel: 'Start Subscription', # LOCALIZE
                token: (data) =>
                    planName = options.plan.toLowerCase()
                    planInterval = options.interval
                    params = {
                        'stripe_token': data.id
                        'plan_id': planName + '-' + planInterval
                    }

                    options.onSuccess(params)
            })

            @.stripeHandler.open({
                name: options.name,
                description: options.description,
                amount: options.amount
            })

module.service("ContribStripeService", ContribStripeService)
