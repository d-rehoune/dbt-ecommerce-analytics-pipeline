{% macro get_product_volume(lenght,height,weight) %}
    {{ lenght }} * {{ height }} * {{ weight }}
{% endmacro %}