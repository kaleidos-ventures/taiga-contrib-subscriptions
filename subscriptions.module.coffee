moduleName = 'subscriptions'

window.taigaContribPlugins = [] if !window.taigaContribPlugins

window.taigaContribPlugins.push({
    type: 'userSettings',
    template: 'compile-modules/taiga-contrib-subscriptions/partials/subscriptions.html',
    name: 'Paid Plans',
    slug: 'subscriptions',
    module: moduleName,
    userMenu: true,
    headerMenu: true,
    authenticated: true,
    headerHtml: (user) ->
        if user.get('max_private_projects') == 1
            return "<div class='upgrade-header-button'>Upgrade</div>"
        return ""
})

angular.module(moduleName, [])
