aws_elastic_lb 'elb_qa' do
  aws_access_key 'AKIAJPBTUETOQUPT2FFA'
  aws_secret_access_key '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'
  #name 'devops-763772721.us-west-2.elb.amazonaws.com'
  name 'devops'
  action :register
end
