
/*
 * Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
 * Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
 * Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
 * Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
 * Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
 * Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * File: subscriptions.coffee
 */

(function() {
  var SubscriptionsAdmin, SubscriptionsService, bindMethods, module,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  SubscriptionsAdmin = (function() {
    SubscriptionsAdmin.$inject = ["$scope", "tgAppMetaService", "tgSubscriptionsService"];

    function SubscriptionsAdmin(scope, appMetaService, subscriptionsService) {
      var description, title;
      this.scope = scope;
      this.appMetaService = appMetaService;
      this.subscriptionsService = subscriptionsService;
      this.scope.pluginName = "Subscriptions - User Profile - Taiga";
      this.scope.sectionName = "Upgrade Plan";
      console.log(this.subscriptionsService.getMyRecommendedPlan());
      this.scope.myRecommendedPlan = this.subscriptionsService.getMyRecommendedPlan();
      title = this.scope.pluginName;
      description = this.scope.sectionName;
      this.appMetaService.setAll(title, description);
    }

    return SubscriptionsAdmin;

  })();

  module = angular.module('taigaContrib.subscriptions', []);

  module.controller("ContribSubscriptionsAdminController", SubscriptionsAdmin);

  bindMethods = (function(_this) {
    return function(object) {
      var dependencies, methods;
      dependencies = _.keys(object);
      methods = [];
      _.forIn(object, function(value, key) {
        if (indexOf.call(dependencies, key) < 0) {
          return methods.push(key);
        }
      });
      return _.bindAll(object, methods);
    };
  })(this);

  SubscriptionsService = (function() {
    SubscriptionsService.$inject = ["$tgHttp"];

    function SubscriptionsService(http) {
      this.http = http;
      bindMethods(this);
    }

    SubscriptionsService.prototype.getMyRecommendedPlan = function() {
      var url;
      url = "http://localhost:5000/api-front/v1/my-recommended-plan";
      return this.http.get(url, {}).then(function(response) {
        console.log('trolororo');
        return response.data;
      });
    };

    return SubscriptionsService;

  })();

  module.service("tgSubscriptionsService", SubscriptionsService);

}).call(this);
