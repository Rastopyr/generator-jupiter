
name = "<%= name %>"

data = <% if(ftype == 'multiple') { %>[]<% } else { %>null<% } %>
  
exports = {
  name
  data
}

module.exports = exports
