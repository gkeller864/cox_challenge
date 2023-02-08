locals {
  vpc_id                 = data.aws_vpc.selected.id
  private_subnets        = data.aws_subnet.selected_private.id
  public_subnets         = data.aws_subnet.selected_public.id
}