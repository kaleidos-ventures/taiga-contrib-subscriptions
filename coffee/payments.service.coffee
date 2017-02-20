###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: payments.service.coffee
###

module = angular.module('subscriptions')

class ContribPaymentsService
    @.$inject = ["$tgConfig", "$translate"]

    constructor: (@config, @translate) ->

    start: (options) ->
        ljs.load "https://checkout.quaderno.io/checkout.js", =>
            options.onLoad()

            key = @config.get("quadernoKey")

            @.quadernoHandler = QuadernoCheckout.configure({
                key: key,
                locale: @translate.use(),
                callback: (params) ->
                    options.onSuccess({quaderno_token: params.details})
            })

            panelLabel = @translate.instant('SUBSCRIPTIONS.SELECT_PLAN.START_SUBSCRIPTION')
            panelLabel += '<br />'
            panelLabel += '<span style="font-size:75%">'
            panelLabel += @translate.instant('SUBSCRIPTIONS.SELECT_PLAN.PAY', {amount: '{{amount}}'})
            panelLabel += '</span>'

            @.quadernoHandler.open({
                type: 'subscription',
                amount: options.amount * 100,
                plan: options.planId,
                currency: options.currency,
                description: options.description,
                first_name: options.full_name,
                email: options.email,
                color: "#5b8200",
                panel_label: panelLabel,
                billing_address: true
            })

    changeData: (options) ->
        ljs.load "https://checkout.stripe.com/checkout.js", =>
            key = @config.get("stripeKey")

            image = "/#{window._version}/images/taiga-contrib-subscriptions/images/custom.png"

            label = @translate.instant("SUBSCRIPTIONS.PAYMENT_HISTORY.CHANGE_DATA")
            @.stripeHandler = StripeCheckout.configure({
                key: key,
                image: image,
                locale: @translate.use(),
                billingAddress: false,
                panelLabel: label
                token: (data) =>
                    params = {
                        'stripe_token': data.id
                    }

                    options.onSuccess(params)
            })

            @.stripeHandler.open({
                name: options.name,
                description: options.description,
                amount: options.amount
            })

    seeBilling: (options) ->
        ljs.load "https://billing.quaderno.io/billing.js", =>

            key = @config.get("quadernoKey")

            @.quadernoBillingHandler = QuadernoBilling.configure({
                key: key,
                customer_id: options.secure_id,
                editable: true
            })

            @.quadernoBillingHandler.open()

module.service("ContribPaymentsService", ContribPaymentsService)
