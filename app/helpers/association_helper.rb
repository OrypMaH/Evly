module AssociationHelper
  def link_to_add_association(name, f, association, options = {})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render(options[:partial], f: builder)
    end
    
    link_to name, '#', 
            class: "ui basic button #{options[:class]}",
            data: {
              association: association,
              fields: fields.gsub("\n", ""),
              insertion_node: options[:data]&.[](:association_insertion_node) || '#' + association.to_s
            },
            onclick: "addAssociation(event, this)"
  end
end