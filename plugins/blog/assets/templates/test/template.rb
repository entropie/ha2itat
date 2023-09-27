def post_background
  if target.image
    %Q(<div class="post-background" style="background-image: url(#{target.image.url})"></div>)
  else
    ""
  end
end


ret = <<-DOC
#{post_background}
<div class="post-content">

<h1>#{title}<br /><small>#{author}</small></h1>

<small>#{target.to_human}</small>

<p>#{content}</p>
</div>
DOC


@result = ret


