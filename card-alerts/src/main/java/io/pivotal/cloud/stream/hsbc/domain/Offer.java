package io.pivotal.cloud.stream.hsbc.domain;


import java.util.Date;

/**
 * @author Vinicius Carvalho
 */
public class Offer {

	private Long voucherId;

	private Long offerId;

	private Long customerId;

	private Date issuedAt;

	private Date expiresAt;

	private Date acceptedAt;


	public Long getVoucherId() {
		return voucherId;
	}

	public void setVoucherId(Long voucherId) {
		this.voucherId = voucherId;
	}

	public Long getOfferId() {
		return offerId;
	}

	public void setOfferId(Long offerId) {
		this.offerId = offerId;
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public Date getIssuedAt() {
		return issuedAt;
	}

	public void setIssuedAt(Date issuedAt) {
		this.issuedAt = issuedAt;
	}

	public Date getExpiresAt() {
		return expiresAt;
	}

	public void setExpiresAt(Date expiresAt) {
		this.expiresAt = expiresAt;
	}

	public Date getAcceptedAt() {
		return acceptedAt;
	}

	public void setAcceptedAt(Date acceptedAt) {
		this.acceptedAt = acceptedAt;
	}
}
